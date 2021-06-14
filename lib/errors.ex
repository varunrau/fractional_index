defmodule FractionalIndex.Errors do
  @type midpointError :: :wrong_order | :trailing_zero

  @type keyError :: :invalid_order_key_head | :invalid_key | :invalid_order_key

  @type error :: midpointError | keyError
end
