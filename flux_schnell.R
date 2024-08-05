# Load required libraries
library(httr)  # For making HTTP requests
library(jsonlite)  # For parsing JSON responses

# Function to generate images using the Replicate API with the FLUX.1[schnell] model
#
# Args:
#   api_token (character): API token for authenticating requests
#   seed (integer): Random seed for generating the image
#   prompt (character): Prompt for generating the image
#   aspect_ratio (character): Aspect ratio of the generated image
#   output_format (character): Format of the generated image
#   output_quality (integer): Quality of the generated image (0-100)
#
# Returns:
#   image_info (list): Information about the generated image, including ID, model, version, input, logs, creation date, status, and image URL
flux_schnell <- function(api_token,
                         seed,
                         prompt,
                         aspect_ratio,
                         output_format,
                         output_quality) {
  
  # URL for making predictions
  url <- "https://api.replicate.com/v1/models/black-forest-labs/flux-schnell/predictions"
  
  # Define the input for the model
  input <- list(
    input = list(
      seed = seed,
      prompt = prompt,
      aspect_ratio = aspect_ratio,
      output_format = output_format,
      output_quality = output_quality
    )
  )
  
  # Make the API request to create the prediction
  response <- POST(
    url,
    add_headers(
      Authorization = paste("Bearer", api_token),
      `Content-Type` = "application/json"
    ),
    body = toJSON(input, auto_unbox = TRUE),
    encode = "json"
  )
  
  # Check for errors in the API response
  stop_if_not_successful(response)
  
  # Parse the response
  result <- content(response, as = "parsed", type = "application/json")
  
  # Extract the prediction URL
  prediction_url <- result$urls$get
  
  # Wait for the prediction to complete
  prediction_status <- wait_for_prediction(prediction_url, api_token)
  
  # Extract image URL
  image_url <- prediction_status$output
  
  # Download the image
  download_image(image_url, output_format, result$id)
  
  # Output all relevant information
  image_info <- list(
    id = result$id,
    model = result$model,
    version = result$version,
    input = result$input,
    logs = result$logs,
    created_at = result$created_at,
    status = prediction_status$status,
    image_url = image_url
  )
  
  return(image_info)
}

# Stop if the API response is not successful
stop_if_not_successful <- function(response) {
  if (status_code(response) != 201) {
    stop(paste("Ошибка в запросе:", status_code(response)))
  }
}

# Wait for the prediction to complete
wait_for_prediction <- function(prediction_url, api_token) {
  while (TRUE) {
    prediction_status <- GET(prediction_url, add_headers(Authorization = paste("Bearer", api_token)))
    
    # Check if the prediction status is completed
    status_content <- content(prediction_status, as = "parsed", type = "application/json")
    status <- status_content$status
    
    if (status == "succeeded") {
      break
    }
    
    if (status == "failed") {
      stop("Prediction failed")
    }
    
    Sys.sleep(3)  # Wait before polling again
  }
  
  return(status_content)
}

# Download the image
download_image <- function(image_url, output_format, filename) {
  download.file(image_url,
                destfile = paste0(filename, ".", output_format),
                mode = "wb")
}

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
image_info
