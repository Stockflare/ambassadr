module Ambassadr
  # The Services namespace is designed to provide a programmatic layer of
  # micro-service integration with minimal configuration required.
  #
  # @example Basic usage of the Services namespace.
  #
  #   Given the micro-service "user", that is a simple API that controls users
  #   within our system (based upon CRUD & REST) and has the following Dockerfile:
  #
  #     ```
  #     FROM bruw/base
  #
  #     ENV PORT 2345
  #
  #     LABEL ambassadr.services.user=env:PORT
  #
  #     LABEL ambassadr.host=2345
  #
  #     EXPOSE 2345
  #
  #     CMD ["puma"]
  #     ```
  #
  #   We can now run this "user" service inside of Ambassadr, using the Services
  #   namespace to "automagically" integrate this service into any other service,
  #   using the following:
  #
  #   `> Services::User.create({ username: 'david', password: '1234' })`
  #
  #   This line would use Ambassadr to dynamically discover an available host and
  #   would send a POST request, to the path "/" with the body containing
  #   the username and password fields.
  #
  #   All responses from `Services` are parsed using Hashie, meaning that you can
  #   use dot-accessors to quickly iterate over the response.
  #
  # @example Nested routes services usage
  #
  #   Now we have established the basic usage of a micro-service named "user",
  #   in the previous example, lets work through an example of updating the
  #   attributes of a pre-existing admin user.
  #
  #   The "gotcha" here, is that to update an admin, we must use a sub-path,
  #   aptly located under the route "/admins/:id". Wereas before, users were
  #   simply mapped to the root path.
  #
  #   To use nested routes within a service, we must instantiate a service object.
  #
  #   `> admin = Services::User.new(:admins, admin_id)
  #
  #   With this new object, given the admin ID of 1234, this will now map
  #   calls to a nested path, namely "/admins/1234/" within the "user" micro-
  #   service.
  #
  #   We can now very simply update this admin user by calling:
  #
  #   `> admin.update({ name: "David" })`
  #
  #   This will progamatically map this call to an associated micro-service
  #   endpoint, using the CRUD standard for updating an instrument.
  class Services

    autoload :Mapper, 'ambassadr/services/mapper'
    autoload :Transport, 'ambassadr/services/transport'
    autoload :Response, 'ambassadr/services/response'
    autoload :Errors, 'ambassadr/services/errors'

    include Mapper

  end
end
