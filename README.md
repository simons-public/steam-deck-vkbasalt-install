# steam-deck-vkbasalt-install
Install vkBasalt on the Steam Deck without modifying the immutable OS filesystem. 

To install via ssh or local terminal:

```
$ wget https://github.com/simons-public/steam-deck-vkbasalt-install/raw/main/vkbasalt_install.sh
$ bash vkbasalt_install.sh
```

To remove, delete the following files/directories:

```
/home/deck/.config/vkBasalt
/home/deck/.config/reshade
/home/deck/.local/lib/libvkbasalt.so
/home/deck/.local/lib32/libvkbasalt.so
/home/deck/.local/share/vulkan/implicit_layer.d/vkBasalt.json
/home/deck/.local/share/vulkan/implicit_layer.d/vkBasalt.x86.json
```

Thanks to DadSchoorse for [vkBasalt](https://github.com/DadSchoorse/vkBasalt). Thanks to dr460nf1r3 and the contributors at [Chaotic-AUR](https://aur.chaotic.cx/).
