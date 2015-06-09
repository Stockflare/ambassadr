FROM bruw/base

ENV HOST_IP 127.0.0.1

ENV PORT 2345

LABEL ambassadr.services.foo=env:PORT

LABEL ambassadr.services.internal.user=4444

LABEL ambassadr.host=env:HOST_IP

EXPOSE 2345

EXPOSE 4444

ENTRYPOINT ["dotenv", "bundle", "exec", "bin/ambassador"]
