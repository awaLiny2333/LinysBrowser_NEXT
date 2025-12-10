"C:\Program Files\Huawei\DevEco Studio\tools\node\node.exe" "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js" --sync -p product=default --analyze=normal --parallel --incremental --daemon
"C:\Program Files\Huawei\DevEco Studio\tools\node\node.exe" "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p product=default assembleHap --analyze=normal --parallel --incremental --daemon

set PROJECT_PATH="E:\linys\Harmony_Projects\Linys_Browser_NEXT\"

echo F| xcopy %PROJECT_PATH%"home\build\default\outputs\default\home-default-unsigned.hap" %PROJECT_PATH%"build_auto\HMOS-home-default-unsigned.hap" /Y