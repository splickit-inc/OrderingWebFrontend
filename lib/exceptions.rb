class APIError < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end

class PromoError < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end

class GroupOrderError < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end

class InvalidPromotion < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end

class InvalidGroupOrder < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end

class PasswordMismatch < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end

class MissingAddress < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end

class NotSignedIn < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end

class OrderingDown < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end

class MissingTip < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end

class MissingCarData < StandardError
  attr_accessor :message, :data
  def initialize message = '', data = {}
    @message = message
    @data = data
  end
end
