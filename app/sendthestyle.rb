class SendTheStyle
  ## handle index request
  get "/" do
    'Send It!'
  end

  ## handle 404 errors
  not_found do
    'Page Not Found'
  end
end
