# ambassadr

This gem makes use of Docker and ETCD to ambassador any program ran within it.

This gem is designed to be used inside a Docker container, running alongside Etcd. Typical of a CoreOS or similar environment.

It is capable of "wrapping" any executable within a forked process and publishing any described endpoints to Etcd, using the Docker Daemon API. The best use case for this is running an API inside the gem, such like:

```
docker run -P -v /var/run/docker.sock:/var/run/docker.sock \
           -d my-company/api ambassador rackup \
           -etcd localhost:4001 -docker unix:///var/run/docker.sock
```

In-order to ambassador "anything", such as [NSQ](http://nsq.io/) for example, Ambassador requires LABEL definitions in the Dockerfile of the container that it will run within. The easiest way to get setup, is to run through a worked example.

## Example

Lets take a very simple API, such as the [Bruw base API](https://github.com/bruw/api-base). Making use of Grape and Rack, you simply start the API by running `rackup`. It has a single API call, `/ping`.

Now we're going to build Ambassador into it, enabling us to run this super-complex API (which we'll aptly name "base") inside our CoreOS environment, allowing other services using Ambassador to very easily and programmatically access the HTTP API that it provides.

### Modifying the Dockerfile

Add the required `LABEL` definitions to the Dockerfile that will run the "base" service:

```
...

# This LABEL defines the "base" service, telling ambassador that it is bound to
# port 2345.
LABEL ambassadr.services.base=2345

# This label tells ambassador to look for the ENV['HOST_IP'] variable for the
# host address that this container is running inside of. This may resolve to something
# like "10.234.0.23" or a resolvable hostname at runtime.
LABEL ambassadr.host=env:HOST_IP

# Lets expose port 2345, that the "base" service will run on.
PORT 2345

# Define the PORT Environment variable, telling the base service to bind to
# port number
ENV PORT 2345

# Sets the entrypoint to always run Ambassadr before anything else
ENTRYPOINT ["ambassador"]

...
```

---

### Running an Ambassadr container

Now that the container is built and deployed to our Docker Registry, lets run our container inside of CoreOS using something similar to the following command:

```
docker run -P -e HOST_IP=${PRIVATE_IP} -v \
  /var/run/docker.sock:/var/run/docker.sock \
  -d bruw/base rackup -etcd ${PRIVATE_IP}:4001 -docker unix:///var/run/docker.sock
```

---

**A few things to consider here are:**

* Using `-P` will publish all the ports from our container, allowing Docker to automatically assign them. *There is no need to manually bind port mappings.*
* *There is no need to name the docker container.* If you do, you need to ensure that the container name is unique for that service within the cluster.
* *The Docker socket is passed in as a volume.* This is a minor security issue, but a necessary evil at this point in time.
* The use of `${PRIVATE_IP}` maps to the host's IP address, such as `10.234.0.1`.

---

### Environment Variable Injection

So now lets take a look at what happened when we ran the container, lets also assume that the following keys and values exist within Etcd:

| Key                                | Value                      |
|------------------------------------|----------------------------|
| `/properties/shared/db/mysql/host` | `my-sql-host.aws.com`      |
| `/properties/shared/db/mysql/port` | `3306`                     |
| `/properties/shared/cache/host`    | `my-cache-host.aws.com`    |
| `/properties/shared/cache/port`    | `11211`                    |

Ambassador first connects to Etcd, and injects these properties into our environment variables, so that our "base" service can make use of them, given that the value `/properties/shared` is the default base properties path, the above keys would be injected like `ENV['DB_MYSQL_PORT'] # => "3306"`.

---

### Service Publishing and Discovery

Connecting to the Docker API, Ambassador will then lookup the container it is running within, mapping the published ports to the service ports. Making use of the labels defined within the service Dockerfile. It will then publish the "base" service, setting the following key:

| Key                           | Value                      |
|-------------------------------|----------------------------|
| `/services/base/317782b2a5f7` | `10.234.0.23:32772`        |

0. `/services` - The default services path. *This can be configured by setting `ENV['PUBLISHER_PATH']` variable.*
0. `base` - The name of the service, as set inside the LABEL definition inside the Dockerfile.
0. `317782b2a5f7` - Is the container ID that it the service is running inside of.
0. `10.234.0.23` - Is the value found inside the `HOST_IP` environment variable.
0. `32772` - The published port number that has been assigned by Docker.

---

### Accessing services programatically?

Now that our "base" service is being published, lets make use of the Ambassadr gem within our the API itself. Given the following class inside a similar, but different API service:

```
module UserAPI
  class Services < Ambassadr::Services
  end
end
```

The User API can then simply access the "base" services' `/ping` call by running `UserAPI::Services::Base.ping`. Ambassadr handles everything else.
