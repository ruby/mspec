require 'mspec/guards/guard'

class BlockDeviceGuard < SpecGuard
  def match?
    block = `find /dev /devices -type b 2> /dev/null`
    !(block.nil? || block.empty?)
  end
end

class Object
  def with_block_device
    g = BlockDeviceGuard.new
    g.name = :with_block_device
    yield if g.yield?
  ensure
    g.unregister
  end
end
