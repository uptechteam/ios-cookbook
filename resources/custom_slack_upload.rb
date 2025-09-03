def my_file_upload_to_slack(initial_comment:, file_path:, channels:, api_token:)
    UI.message("🚀 Initiating my file upload to Slack...")

    file_name = File.basename(file_path)
    file_size = File.size(file_path)

    upload_url, file_id = fetch_slack_upload_url_and_file_id(filename: file_name, file_size: file_size, api_token: api_token)

    return unless upload_url && file_id

    return unless perform_file_upload_to_slack(upload_url: upload_url, file_path: file_path, api_token: api_token)

    complete_file_upload_to_slack(
                                  file_id: file_id,
                                  file_name: file_name,
                                  channels: channels,
                                  initial_comment: initial_comment,
                                  api_token: api_token
                                  )
end

def fetch_slack_upload_url_and_file_id(filename:, file_size:, api_token:)
    uri = URI("https://slack.com/api/files.getUploadURLExternal?filename=#{filename}&length=#{file_size}")

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{api_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
    end

    result = JSON.parse(response.body)

    if result['ok']
        UI.message("✅ Successfully obtained upload URL and file ID.")
        return result['upload_url'], result['file_id']
    else
        UI.error("❌ Slack API error: #{result}")
        return nil, nil
    end
end

def perform_file_upload_to_slack(upload_url:, file_path:, api_token:)
    uri = URI(upload_url)

    file_data = File.binread(file_path)
    file_size = file_data.bytesize

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_token}"
    request['Content-Type'] = 'application/octet-stream'
    request.body = file_data

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
    end

    expected_response = "OK - #{file_size}"
    if response.body.strip == expected_response
        UI.message("✅ File data successfully uploaded to Slack.")
        return true
    else
        UI.error("❌ File upload failed. Unexpected response: #{response.body}")
        return false
    end
end

def complete_file_upload_to_slack(file_id:, file_name:, channels:, initial_comment:, api_token:)
    uri = URI("https://slack.com/api/files.completeUploadExternal")

    body = {
        files: [
        {
            id: file_id,
            title: file_name
        }
        ],
        channels: channels,
        initial_comment: initial_comment
    }

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_token}"
    request['Content-Type'] = 'application/json'
    request.body = body.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
    end

    result = JSON.parse(response.body)

    if result['ok']
        UI.message("✅ Slack file upload process fully completed.")
        return true
    else
        UI.error("❌ Failed to complete file upload. Response: #{result}")
        return false
    end
end
