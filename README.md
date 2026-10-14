# Bootanimation Manager

Magisk / KernelSU module with a **WebUI** to preview, download, install and choose your boot animation. Android 14-17, built for OnePlus / OxygenOS 16 (tested on OnePlus 12).
It carries the 64 classic bootanimations of [mythemedarkandmore.altervista.org](https://mythemedarkandmore.altervista.org/bootanimation-manager/), each with an animated preview.

Modulo Magisk / KernelSU con **interfaccia WebUI** per vedere in anteprima, scaricare, installare e scegliere la bootanimation. Android 14-17, pensato per OnePlus / OxygenOS 16 (provato su OnePlus 12). Contiene le 64 bootanimation classiche del sito, ciascuna con anteprima animata.

## Features / Funzioni
- Animated preview of every bootanimation / anteprima animata di ognuna
- **Try now**: plays it full screen for a few seconds, no reboot / la prova a schermo intero senza riavviare
- **Download & use** (Online tab): downloads, installs and activates it; one reboot is enough / scarichi, installi e attivi, basta un riavvio
- **Use this**: turns the chosen one on and the others off / accende quella scelta e spegne le altre
- **From folder**: install zips already on the phone, **Remove** the ones you no longer want / installa zip già sul telefono e rimuovi quelle che non servono
- **Update** tab: updates the Manager (and its catalog) from inside the app, straight from this repository, no reboot / aggiorna il Manager (e il catalogo) dall'app, direttamente da questo repository, senza riavvio. It also checks by itself every 12 hours / controlla da solo ogni 12 ore
- Italian and English / italiano e inglese

## Requirements / Requisiti
- Android 14 or newer / Android 14 o superiore
- KernelSU or KernelSU Next (built-in WebUI), or Magisk with **MMRL** / **WebUI X** to open the module page
- Internet only for the Online tab and updates / internet solo per la scheda Online e gli aggiornamenti

## Install / Installazione
1. Download `release/Magisk_Bootanimation_Manager_A14-A17.zip` and install it from your module manager, then reboot.
2. Open the module with its **WebUI** button.
3. Online tab -> pick one -> **Download & use** -> reboot once.

## Repository layout
- `module/` - the module source (`bam.sh` shell helper, `webroot/` WebUI, `catalog.json`, previews)
- `tools/make_zip.py` - builds the zip into `release/`
- `release/` - the latest ready-to-flash zip

The bootanimation zips themselves are hosted on pCloud (links are in `module/webroot/catalog.json`).
Note: line endings of `*.sh` must stay LF; with CRLF the phone shell fails.

## Credits
Bootanimations: Tullio (tugaia56), most of them more than 10 years old, revived for current Android.
