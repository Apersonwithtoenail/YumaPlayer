#!/bin/bash
echo "🚀 Triggering GitHub Build..."
gh workflow run build.yml -R Apersonwithtoenail/YumaPlayer

echo "⏳ Waiting for build to start..."
sleep 5

# Get the ID of the latest run
RUN_ID=$(gh run list --workflow=build.yml -R Apersonwithtoenail/YumaPlayer --limit 1 --json databaseId -q '.[0].databaseId')

echo "👀 Watching build $RUN_ID..."
gh run watch $RUN_ID -R Apersonwithtoenail/YumaPlayer

# Check if it succeeded
STATUS=$(gh run view $RUN_ID -R Apersonwithtoenail/YumaPlayer --json conclusion -q '.conclusion')

if [ "$STATUS" == "success" ]; then
    echo "✅ Build successful! Downloading APK..."
    rm -rf ./downloaded_apk
    gh run download $RUN_ID -R Apersonwithtoenail/YumaPlayer -n YumaPlayer-Release-APK -D ./downloaded_apk
    
    APK_FILE=$(find ./downloaded_apk -name "*.apk" | head -n 1)
    
    echo "📲 Installing $APK_FILE to phone..."
    adb install -r "$APK_FILE"
    
    echo "🚀 Launching Yuma..."
    adb shell monkey -p moe.rukamori.archivetune -c android.intent.category.LAUNCHER 1
else
    echo "❌ Build failed. Check the logs on GitHub."
fi
