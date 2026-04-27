# Docs Book Cloud Foundry Container 
The repository contains a Ruby 2.6.9 container that includes the functionality to run the Cloud Foundry documentation web server [here](https://github.com/cloudfoundry/docs-book-cloudfoundry) and publishes the image on GitHub packages.

## Set up the Container and inject the corresponding documentation structure

You can specify the injected documentation repository as mounted volume under the `/tmp` directory. The following example gives you an overview how you can specify it.
```yaml
    volumes:
      - /<directory>/cf/docs-dev-guide:/tmp/docs-dev-guide
```

## Start the container via the compose file

You can start the container manually, or you can use the `docker-compose up -d` command to run it in daemon mode and open the documentation inside your browser under `localhost:4567`.

## Hot Reload

The container ships with a built-in hot reload feature powered by [browser-sync](https://browsersync.io/). When a documentation source file (`.md`, `.erb`, `.html`, `.yml`) inside any mounted volume under `/tmp` changes, the browser automatically refreshes with the updated content.

| Port | Description |
|------|-------------|
| `4567` | Bookbinder (Middleman) server – direct access without hot reload |

Open `http://localhost:4567` in your browser to take advantage of the automatic reload on file changes.
