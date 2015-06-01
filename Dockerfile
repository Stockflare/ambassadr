FROM busybox

ENV HOST_IP 127.0.0.1

LABEL ambassadr.service=val:test

LABEL ambassadr.host=env:HOST_IP
