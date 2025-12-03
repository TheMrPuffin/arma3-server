# Arma 3 Dedicated Server – Docker

> ⚠️ This project is under early active development.

This repository provides a fully containerised Arma 3 dedicated server built on top of the
[`cm2network/steamcmd`](https://hub.docker.com/r/cm2network/steamcmd) base image.

The latest version is rebuilt nightly with the latest `cm2network/steamcmd` version.

The container will:

- Use SteamCMD to download or update Arma 3 on start
- Launch the dedicated server with a configurable `server.cfg` loaded from environment variables or can be overriden from mounted configuration file

---

## 🚀 Getting Started

### Prerequisites

To run this image you’ll need:

- **Docker** installed and running  
- A **Steam account**
*(It is recommended to create a separate Steam account for this server.  
The Arma 3 Dedicated Server package is available for free — you do **not** need to purchase Arma 3.)*
- **Open network ports** on your host (default: `2302/udp,2303/udp,2304/udp,2306/udp`)

### Quick start (Docker)

```sh
docker run -d \
  --name arma3-server \
  -e STEAM_USER="your_steam_username" \
  -e STEAM_PASSWORD="your_steam_password" \
  -p 2302:2302/udp \
  -p 2303:2303/udp \
  -p 2304:2304/udp \
  -p 2306:2306/udp \
  -v arma3-data:/home/steam/arma3/server \
  ghcr.io/themrpuffin/arma3-server:latest
```

This does the following:

- Runs the container in the background (-d)
- Logs into Steam using **STEAM_USER** and **STEAM_PASSWORD**
- Forwards Arma 3 UDP ports from your host
- Persists the downloaded server files in a Docker volume called arma3-data
- Uses default Arma 3 dedicated server config

If you want to make configuration changes, see below.

## ⚙️ Configuration

For a full list of available Arma 3 dedicated server configuration options, see the official  
**Arma 3 Server Config File documentation:**  
🔗 <https://community.bistudio.com/wiki/Arma_3:_Server_Config_File>

You can configure the server in two ways:

1. **By mounting your own `server.cfg`**  
2. **By using `A3_`-prefixed environment variables** (auto-generated config)

---

### Option 1: Mount an existing `server.cfg`

If you already have a complete Arma 3 config, you can mount it into the container at
`/mnt/server.cfg`.
If this file is present, the startup script will not generate a config — your file takes priority.

**Example:**

```sh
docker run -d \
  --name arma3-server \
  -e STEAM_USER="your_steam_username" \
  -e STEAM_PASSWORD="your_steam_password" \
  -p 2302:2302/udp \
  -p 2303:2303/udp \
  -p 2304:2304/udp \
  -p 2306:2306/udp \
  -v /path/to/your/server.cfg:/mnt/server.cfg:ro \
  ghcr.io/themrpuffin/arma3-server:latest
```

### Option 2: Configure using `A3_` environment variables

If `/mnt/server.cfg` is not mounted, the container auto-generates a config file using all
environment variables beginning with `A3_`.

- The prefix **`A3_` is removed**
- Whatever remains becomes the **Arma 3 config key**
- The startup script decides whether to emit a **scalar** (`key = value;`) or an **array**
  (`key[] = { ... };`)

---

#### Scalar values

If the value matches `^[0-9.]+$`, it is treated as a **number**.  
Otherwise, it is treated as a **string** and wrapped in quotes.

**Examples:**

```sh
# hostname = "My Cool Server";
-e A3_hostname="My Cool Server"

# maxPlayers = 32;
-e A3_maxPlayers=32

# passwordAdmin = "supersecret";
-e A3_passwordAdmin=supersecret

# verifySignatures = 2;
-e A3_verifySignatures=2
```

These would produce:

```cfg
hostname = "My Cool Server";
maxPlayers = 32;
passwordAdmin = "supersecret";
verifySignatures = 2;
```

#### Array values

If the value contains a comma (,) or a pipe (|), it’s treated as an array.
Both separators are supported, and all items are always quoted as strings.

**Examples:**

```sh
# motd[] = { "Welcome to my server.", "Hosted in the net." };
-e A3_motd="Welcome to my server.,Hosted in the net."

# headlessClients[] = { "10.0.0.10", "10.0.0.11" };
-e A3_headlessClients="10.0.0.10|10.0.0.11"

# admins[] = { "1234567890", "0987654321" };
-e A3_admins="1234567890,0987654321"
```

The script:

- Splits the value on , or |
- Wraps each item in quotes
- Emits a config line like:

```cfg
key[] = { "item1", "item2" };
```

#### Putting it together – full example

```sh
docker run -d \
  --name arma3-server \
  -e STEAM_USER="your_steam_username" \
  -e STEAM_PASSWORD="your_steam_password" \
  -e A3_hostname="Docker Arma 3" \
  -e A3_maxPlayers=16 \
  -e A3_passwordAdmin="changeme" \
  -e A3_motd="Welcome to my server.,Hosted in the net." \
  -e A3_admins="76561198000000000,76561198000000001" \
  -p 2302:2302/udp \
  -p 2303:2303/udp \
  -p 2304:2304/udp \
  -p 2306:2306/udp \
  -v arma3-data:/home/steam/arma3/server \
  ghcr.io/themrpuffin/arma3-server:latest
```

On startup, this will generate a server.cfg containing (among other things):

```cfg
hostname = "Docker Arma 3";
maxPlayers = 16;
passwordAdmin = "changeme";
motd[] = { "Welcome to my server.", "Hosted in the net." };
admins[] = { "76561198000000000", "76561198000000001" };
```

## Steam Workshop Mods

> ⚠️ This function only works if the Steam account actaully owns Arma 3.

You can load Steam Workshop mods by setting the `STEAM_MODS` environment variable.
Just provide a list of Workshop item IDs and the container will download and load them automatically.

```sh
-e STEAM_MODS="450814997, 620019431"
```

## 🧭 Roadmap

This project is under active development.  
Below is an overview of planned features, improvements, and long-term goals.

### ✅ Completed

- ✔️ Base Docker image using `cm2network/steamcmd` to download and run Arma 3 server
- ✔️ Support for mounting a custom `server.cfg`
- ✔️ Environment-variable–driven config (`A3_` prefix system)
- ✔️ Steam Workshop mod auto-download

---

### 🚧 In Progress

- ⏳ Helm chart for Kubernetes deployment

---

### 🧪 Planned / Future / Nice-to-Have

- 📌 Graceful shutdown with server save/notification
- 📌 Support for mods (server-side mod loading)
- 📌 Steam Workshop mission auto-download
- 📌 Manual mod loading
- 📌 Basic health checks & lifecycle hooks (readiness/liveness probes)
- 📌 Support for headless clients (HC)

---

If you have feature requests or suggestions, feel free to open an issue or PR!
