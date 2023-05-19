response=$(curl --location --request POST 'https://stablediffusionapi.com/api/v3/text2img' \
--header 'Content-Type: application/json' \
--data-raw '{
  "key": "xyz",
  "prompt": "ultra realistic close up portrait ((beautiful pale cyberpunk female with heavy black eyeliner))",
  "negative_prompt": null,
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