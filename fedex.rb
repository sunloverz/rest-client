# frozen_string_literal: true

require "rest-client"
require "openssl"
require "json"
require "time"

class FedexClient
  APP_ID = "test"
  APP_KEY = "test22"
  SECRET = "3026946d4f6d5d04"
  URL = "https://apideclarationuat.fedex.com.cn/API/d/check"

  def self.check
    timestamp = (Time.now.to_f * 1000).to_i.to_s
    token = OpenSSL::Digest::SHA256.hexdigest("#{APP_ID}#{APP_KEY}#{SECRET}#{timestamp}")

    headers = {
      "AppId" => APP_ID,
      "AppKey" => APP_KEY,
      "TimeStamp" => timestamp,
      "token" => token,
      "Accept" => "application/json"
    }

    pdf_paths = [
      '/Users/aomurbekov/Documents/test/123456321333.pdf',
      '/Users/aomurbekov/Documents/test/123456321444.pdf',
      '/Users/aomurbekov/Documents/test/12345632133333.pdf'
    ]

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
          consignmentCode: '983456789013',
          contactInformation: '13888888888',
          contacts: '李四',
          operateUnitCode: '0987654321',
          operateUnitName: '联邦快递（中国）有限公司',
          pickupCity: 'shanghai'
        }
      }
    )

    file_ios = pdf_paths.map { |p| File.open(p, 'rb') }
    pairs = file_ios.map { |io| ['files', io] } + [["params", params_json]]
    payload = RestClient::Payload::Multipart.new(RestClient::ParamsArray.new(pairs))

    begin
      response = RestClient::Request.execute(
        method: :post,
        url: URL,
        headers: headers,
        payload: payload
      )

      puts "Status: #{response.code}"
      puts response.body
      response
    rescue RestClient::ExceptionWithResponse => e
      warn "HTTP #{e.http_code}"
      warn(e.response ? e.response.body : e.message)
      raise
    rescue StandardError => e
      warn e.message
      raise
    ensure
      file_ios.each { |io| io.close unless io.closed? }
    end
  end
end

