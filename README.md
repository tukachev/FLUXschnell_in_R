# FLUXschnell_in_R

Function to generate images using the [Replicate API](https://replicate.com) with the [FLUX.1[schnell] model](https://blackforestlabs.ai/announcing-black-forest-labs/)

```{r}
# Example usage
api_token <- Sys.getenv("REPLICATE_API_TOKEN")
seed <- 666
prompt <- "An anthropomorphic robot holds a sign with the text 'User Group RLang Ru' on it"
aspect_ratio <- "1:1"
output_format <- "jpg"
output_quality <- 100

image_info <- flux_schnell(api_token,
                           seed,
                           prompt,
                           aspect_ratio,
                           output_format,
                           output_quality)
```

![](bpbq9pa14hrm20ch3x6bgrmhwm.jpg)
