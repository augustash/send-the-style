# add current directory to load path
$:.unshift File.dirname(__FILE__)

# load the middleware
require "lib/exception_handling"

# load the application
require "api/sendthestyle"

# register exception middleware
use ExceptionHandling

# fire it up!
run Api::SendTheStyle
