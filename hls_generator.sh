#!/usr/bin/env bash


set -o nounset
set -o errexit
set -o pipefail


OUTPUT_DIR="fake_stream"
OUTPUT_BASENAME="chunks"

if [[ $# -ne 1 ]]; then
    echo "Usage:"
    echo "    $0 <video_file_to_stream>"
    exit 1
fi

input_file=$1

if [ -d "$OUTPUT_DIR" ]; then
    echo "Deleting old chunks from folder ${OUTPUT_DIR}..."
    find "$OUTPUT_DIR" -type f -iname "${OUTPUT_BASENAME}*" -delete
else
    echo "$OUTPUT_DIR does not exist. Creating an empty folder with default master.m3u8 file."
    mkdir $OUTPUT_DIR
    cp default_master.m3u8 $OUTPUT_DIR/master.m3u8
fi

echo "Launching ffmpeg..."
ffmpeg \
    -stream_loop -1 \
    -re \
    -i $input_file \
    -map 0 \
    -c copy \
    -f hls \
    -hls_flags +delete_segments+split_by_time \
    -hls_time 6 \
    -hls_list_size 6 \
    "${OUTPUT_DIR}/${OUTPUT_BASENAME}.m3u8" &

echo "Launching python server..."
python -m http.server 8000 --directory ${OUTPUT_DIR}
