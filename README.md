# ambassadr

This gem makes use of Docker and ETCD to ambassador any program ran within it.

Assuming some defaults, providing an ambassador for your application is as simple as running: `$ docker run -d -P my-company/api ambassador rackup`

This will publish your service in a discoverable manner to ETCD, whilst injecting cloud configuration based upon some sensible defaults into your application.

---

Work in progress...
