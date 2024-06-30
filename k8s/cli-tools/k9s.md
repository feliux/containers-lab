# K9s

Consider K9s as another cluster administration command-line tool next to other tools such as kubectl, helm, istioctl, and the like.

```sh
$ curl -sS https://webinstall.dev/k9s | bash
$ PATH="/root/.local/bin:$PATH"
$ k9s version
$ k9s info
# Start the K9s dashboard:
$ k9s --all-namespaces

# Commands
:services
:deploy
:pods
:aliases
:pulse # install metric server previously
```

## References

[k9s](https://k9scli.io/)
