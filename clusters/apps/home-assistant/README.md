# Home Assistant

Home Assistant Container (the plain Docker image, without Supervisor/add-ons)
running in the `home-assistant` namespace.

The deployment is intentionally a small set of plain manifests instead of a
Helm chart: there is a single container, a single volume, and a handful of
settings, so this is easier to extend and reason about.

## Access

| From | URL |
| --- | --- |
| Internet (Cloudflare Access-protected) | <https://private-k8s.cristobalszk.dev/> |
| LAN | `http://<node-running-the-pod>:8123` |

Home Assistant does not support running under a sub-path, so it owns the root
of `private-k8s.cristobalszk.dev`. Other applications keep working because
ingress-nginx routes longer paths such as `/grafana` first.

The pod uses `hostNetwork: true`. That is what lets Home Assistant use
mDNS/SSDP to discover devices on the LAN (Chromecast, Sonos, printers, ...),
and it also exposes port `8123` on the node's LAN address. The ingress is in
front of it for access through Cloudflare.

The app lives in its own `home-assistant` namespace, which also keeps it out
of the `default` namespace's auth transformer. Cloudflare Access already
protects the host, and adding the nginx auth service would break the Home
Assistant companion app and inbound webhooks. Home Assistant has its own user
authentication.

The companion app and other clients must go through Cloudflare Access (WARP
authenticates automatically for the allowed emails). Third-party services that
POST to a Home Assistant webhook will be stopped by Access unless you add a
bypass policy for that path in Cloudflare.

## First start

Flux creates the PVC, ConfigMaps, Deployment, Service and Ingress. On the
first start an init container seeds `/config/configuration.yaml`, the empty
`automations.yaml`, `scripts.yaml` and `scenes.yaml` files, and the HTTP
settings store (`.storage/http`), then Home Assistant starts and shows the
onboarding screen. Create the owner account there.

## Configuration

There are two kinds of configuration:

1. **UI-managed (normal use).** Everything created through the Home Assistant
   UI lives on the `/config` PVC: `.storage/`, `automations.yaml`, dashboards,
   integrations, users, etc. It survives pod restarts and image upgrades.

2. **Flux-managed cluster settings.** `configmap-packages.yaml` is mounted
   read-only at `/config/packages` and loaded through
   `homeassistant.packages`. It currently contains the recorder retention
   settings. Edit it in Git, let Flux reconcile, then restart Home Assistant
   so the YAML is re-read.

### HTTP server / reverse proxy settings

Since Home Assistant 2026.8 the HTTP server settings (port, trusted proxies,
IP banning, ...) are stored in `.storage/http` and are managed from
**Settings → System → Network** instead of YAML. A YAML migration exists, but
it stages the imported values as a trial that auto-reverts after 5 minutes
unless someone confirms it in the UI, which is not reliable for a headless
deployment.

Because ingress-nginx always sends `X-Forwarded-For`, Home Assistant returns
HTTP 400 until `use_x_forwarded_for` and `trusted_proxies` are configured. The
init container therefore seeds `.storage/http` from `configmap-seed.yaml`
**only if the file does not exist yet**, with `trusted_proxies` covering the
K3s pod/service networks. After the first start, change these values from the
UI; the seed is never applied again. The values are intentionally not in
`configmap-packages.yaml`, because Home Assistant would ignore them after the
one-time migration.

`configuration.yaml` itself is seeded **only once**, from `configmap-seed.yaml`.
After that it is a normal file on the PVC, so it can be edited without losing
changes on restart:

```bash
kubectl -n home-assistant exec -it deploy/home-assistant -c home-assistant -- vi /config/configuration.yaml
```

If you change `configmap-seed.yaml` later, delete the corresponding file on
the PVC (`/config/configuration.yaml` or `/config/.storage/http`) and restart
to regenerate it (this discards manual edits to that file).

Restart Home Assistant either from **Settings → System → Restart** or with:

```bash
kubectl -n home-assistant rollout restart deployment/home-assistant
```

## Storage

`home-assistant-config` is an `8Gi` PVC on the K3s `local-path` StorageClass.
The volume lives on the node where the pod first ran, under
`/var/lib/rancher/k3s/storage/`, so it is node-bound: if that node is lost,
the data must be restored from a backup.

### Moving to cloud-backed storage later

The StorageClass is a single line in `pvc.yaml`. To move to a cloud-backed
volume:

1. Install a CSI driver/provisioner for the target storage (for example
   Longhorn on-prem, or your cloud provider's CSI driver).
2. Stop Home Assistant (`kubectl -n home-assistant scale deploy/home-assistant --replicas=0`).
3. Create the new PVC with the new `storageClassName` and copy the contents of
   the old volume into it (a temporary pod mounting both PVCs works well).
4. Point `claimName` in `deployment.yaml` at the new PVC, then reconcile and
   scale back up. A PVC's StorageClass cannot be changed in place, so a new
   PVC is needed.

Alternative/complementary option: use Home Assistant's built-in backups
(**Settings → System → Backups**) and add a cloud backup location there. That
protects the data even while the live volume stays on `local-path`.

Home Assistant uses SQLite by default. SQLite is not reliable on NFS, so if you
move `/config` to a network-backed volume, prefer a block-backed CSI volume.
Alternatively, keep the database local (or move it to PostgreSQL later) and
use the built-in backups for off-site copies.

## Devices and USB radios

Network discovery works because of `hostNetwork`. USB Zigbee/Z-Wave sticks
are not wired up yet: that needs the device passed into the pod
(`hostPath`/`privileged`) and the pod pinned to the node where the stick is
plugged in (`nodeSelector` or node affinity). For a network-attached
coordinator (for example a Zigbee2MQTT/SMLIGHT bridge) nothing extra is
needed.

## Resources

Requests are `100m` CPU / `512Mi` memory, limits are `2` CPU / `1536Mi`
memory. Home Assistant can grow beyond that with many integrations; raise the
limit if the pod starts getting OOM-killed. The node has 4 GB of RAM, so keep
an eye on total usage.

## Updating

The image is pinned in `deployment.yaml` and updated by Renovate. Home
Assistant upgrades its database on the first start of a new version; take a
backup before a minor/major upgrade. The `busybox` init image is updated by
Renovate too.

## Troubleshooting

```bash
kubectl -n home-assistant get pods,pvc
kubectl -n home-assistant logs deploy/home-assistant -c home-assistant
kubectl -n home-assistant logs deploy/home-assistant -c seed-config
kubectl -n home-assistant describe ingress ingress-home-assistant
```

A request reaching Home Assistant through the ingress should not log
`A request from a reverse proxy was received ...`. If it does, open
**Settings → System → Network** and check that **Trust X-Forwarded-For** is on
and that the ingress pod network is listed under **Trusted proxies** (K3s uses
`10.42.0.0/16` by default). The seeded values live in `.storage/http` on the
PVC.
