#!/bin/sh

FILE="./frameworks/opt/telephony/src/java/com/android/internal/telephony/data/PhoneSwitcher.java"
BACKUP="${FILE}.bak"

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

echo "Patching $FILE ..."

# Backup orignal file
if [ ! -f "$BACKUP" ]; then
    cp "$FILE" "$BACKUP"
    echo "Backup created: $BACKUP"
fi

# Check status of the patch
if grep -q "RADIO_NOT_AVAILABLE || error == CommandException.Error.INTERNAL_ERR" "$FILE"; then
    echo "Patch already applied."
    exit 0
fi

# Apply the patch
awk '
BEGIN {
    in_method=0
}

/private void onDdsSwitchResponse\(AsyncResult ar\)/ {
    in_method=1
}

{
    if (in_method &&
        $0 ~ /else if \(error == CommandException.Error.RADIO_NOT_AVAILABLE\)/) {

        print "                } else if (error == CommandException.Error.RADIO_NOT_AVAILABLE || error == CommandException.Error.INTERNAL_ERR) {"
        next
    }

    print
}

in_method && /^    }$/ {
    in_method=0
}
' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

echo "Patch applied successfully!"