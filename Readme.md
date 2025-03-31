# d2-convert

A Docker-based project for converting D2 graphs to PNG files. This project is designed to streamline and simplify conversion tasks using containerized environments.
The produced image contains tools required to run the following pipe

```bash
COLOR=$(d2 test.d2 - | rsvg-convert -f png - | convert png:- -format "%[pixel:p{1,1}]" info:-) && d2 test.d2 - | rsvg-convert -f png - | convert png:- -transparent "$COLOR" -trim +repage test.png
```

in the container. The shown pipe converts D2 graph to PNG file with transparent background and proper bounding box.

The final command to convert file without installing any other tools except docker looks like

```bash
docker run --rm -u $(id -u):$(id -g) -v "$PWD":/data -w /data pzktit/d2-convert bash -c 'COLOR=$(d2 test.d2 - | rsvg-convert -f png - | convert png:- -format "%[pixel:p{1,1}]" info:-) && d2 test.d2 - | rsvg-convert -f png - | convert png:- -transparent "$COLOR" -trim +repage test.png'
```

In a `script` folder you can a sample script that converts all modified D2 files in a working folder.
