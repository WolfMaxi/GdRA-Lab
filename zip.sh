#!/bin/sh
suffix="V5"
zip -r "lab.zip" . -x ".gitignore" ".git/*" ".devcontainer/*" "vhdl_ls.toml" "documents/*" "zip.sh" "*.cf" "*.vcd" "*.ghw"
cp "lab.zip" "Maximilian_Wolf_${suffix}.zip"
mv "lab.zip" "Esad_Cekmeci_${suffix}.zip"
