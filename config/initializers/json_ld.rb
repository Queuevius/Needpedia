JSON::LD::Context::PRELOADED = {
    'https://www.w3.org/ns/activitystreams' => JSON.parse(File.read(Rails.root.join('config', 'activity_streams.jsonld')))
}