require 'http_signatures'

# No need for the `configure` method. Instead, we'll set up a reusable context.
HttpSignatureContext = HttpSignatures::Context.new(
    keys: {}, # Keys will be added dynamically
    algorithm: 'rsa-sha256',
    headers: ['(request-target)', 'host', 'date', 'digest', 'content-type']
)