require 'rest-client'
require 'json'

url = 'https://apideclarationuat.fedex.com.cn/API/d/check'

headers = {
  'AppId'     => 'test',
  'AppKey'    => 'test123',
  'TimeStamp' => '1757917066009',
  'token'     => '7bd5f2a3bbbaf70e4789362eebe021eaa64c2662ad59735493cb93d98f366620',
  'Accept'    => 'application/json'
}

pdf_paths = [
  '/Users/aomurbekov/Documents/test/123456321333.pdf',
  '/Users/aomurbekov/Documents/test/123456321444.pdf',
  '/Users/aomurbekov/Documents/test/12345632133333.pdf'
]

# Build the JSON string for the 'params' form field
params_json = JSON.generate(
  head: {
    declareType: 3,
    fileTypes: [
      { fileName: '123456321333.pdf',   code: 1 },
      { fileName: '123456321444.pdf',   code: 2 },
      { fileName: '12345632133333.pdf', code: 3 }
    ]
  },
  content: {
    declareHead: {
      consignmentCode: '123456789013',
      contactInformation: '13888888888',
      contacts: '李四',
      operateUnitCode: '0987654321',
      operateUnitName: '联邦快递（中国）有限公司',
      pickupCity: 'shanghai'
    }
  }
)

# Prepare file parts (multipart). Using UploadIO lets us set content types and filenames explicitly.
files_ios = pdf_paths.map do |path|
  RestClient::Payload::UploadIO.new(File.new(path, 'rb'), 'application/pdf', File.basename(path))
end

# Note: rest-client will encode arrays as repeated fields with [] (files[]).
# Most servers accept this the same as multiple --form files=... entries in curl.
payload = {
  multipart: true,
  'params' => params_json,
  'files' => files_ios
}

begin
  response = RestClient::Request.execute(
    method: :post,
    url: url,
    headers: headers,
    payload: payload
  )

  puts "Status: #{response.code}"
  puts response.body
rescue RestClient::ExceptionWithResponse => e
  warn "HTTP #{e.http_code}"
  warn(e.response ? e.response.body : e.message)
rescue StandardError => e
  warn e.message
end

