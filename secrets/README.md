# Secret keys

Host secrets are stored in `secrets/falcon.yaml` and encrypted with SOPS.

Add the GitHub push token under this key:

```yaml
github_pat_push_to_falcon: <fine-grained GitHub PAT>
```

Edit the encrypted file immediately with:

```sh
nix shell nixpkgs#sops -c sops secrets/falcon.yaml
```

After the host has been rebuilt with `sops` installed, this shorter command also works:

```sh
sops secrets/falcon.yaml
```

Keep the token value out of plaintext files, shell history, and tracked Nix files.
