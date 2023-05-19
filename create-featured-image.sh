#!/bin/bash
set -x

echo "#################################################"
echo "Run the code to create a featured image"

prompt="a tiny finch on a branch with (spring flowers on background 1.0), aesthetically inspired by evelyn de morgan, art by bill sienki"
echo "Prompt: $prompt"

negative_prompt=""
echo "Negative prompt: $negative_prompt"

# Generate image using Stable Diffusion
# TODO: Add dynamic prompt
# TODO: Add key to GitHub as a personal access token
response=$(curl --location --request POST 'https://stablediffusionapi.com/api/v3/text2img' \
--header 'Content-Type: application/json' \
--data-raw '{
  "key": "g7u5IZQngX1yKxSoYmm5ckU5qTPlUSKYup6KfHAcKiHI2w78gF1MJkBsT7uL",
  "prompt": "'"$prompt"'",
  "negative_prompt": "'"$negative_prompt"'",
  "width": "512",
  "height": "512",
  "samples": "1",
  "num_inference_steps": "20",
  "safety_checker": "no",
  "enhance_prompt": "yes",
  "seed": null,
  "guidance_scale": 7.5,
  "multi_lingual": "no",
  "panorama": "no",
  "self_attention": "no",
  "upscale": "no",
  "embeddings_model": "embeddings_model_id",
  "webhook": null,
  "track_id": null
}')
echo "Response: $response"

# Check if curl command succeeded
if [ $? -eq 0 ]; then
    # Check if the response is not empty
    if [ -n "$response" ]; then
        # Process the response as needed
        echo "API response: $response"
    else
        echo "API response is empty."
    fi
else
    echo "Error: Failed to connect to the API endpoint."
fi

# Check if there is at least one output file
if [ $(echo "$response" | jq '.output | length') -gt 0 ]; then
    
    # There is at least one output file to work with
    echo "At least one item in output"
    
    # Go to the featured-images folder
    cd featured-images

    # Extract the image URL from the response
    image_url=$(echo "$response" | jq -r '.output[0]')
    echo "image_url: $image_url"

    # Get the original filename from the API response
    image_file=$(echo $image_url | awk -F '/' '{print $NF}')
    echo "image_file: $image_file"

    # Get the filename's extension (jpg, png, etc.)
    file_extension="${image_file##*.}"
    echo "file_extension: $file_extension"

    # Create a human-readable name for the new file
    output_filename="test-api"
    echo "output_filename: $output_filename"

    # Combine the ouptut filename and the original API's extension
    final_output_filename="${output_filename}.${file_extension}"
    echo "final_output_filename: $final_output_filename"

    # Use curl to download the image and save it to the new file
    curl -o "$final_output_filename" -J -L "$image_url"

    # Return to root in case you need to do something else
    cd ..
else
    echo "Output is empty"
fi

# delete this code if the if statement above works okay
# # Go to the featured-images folder
# cd featured-images

# # Extract the image URL from the response
# image_url=$(echo "$response" | jq -r '.output[0]')
# echo "image_url: $image_url"

# # Get the original filename from the API response
# image_file=$(echo $image_url | awk -F '/' '{print $NF}')
# echo "image_file: $image_file"

# # Get the filename's extension (jpg, png, etc.)
# file_extension="${image_file##*.}"
# echo "file_extension: $file_extension"

# # Create a human-readable name for the new file
# output_filename="test-api"
# echo "output_filename: $output_filename"

# # Combine the ouptut filename and the original API's extension
# final_output_filename="${output_filename}.${file_extension}"
# echo "final_output_filename: $final_output_filename"

# # Use curl to download the image and save it to the new file
# curl -o "$final_output_filename" -J -L "$image_url"
