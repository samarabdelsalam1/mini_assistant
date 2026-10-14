module Assistant
  class CookieMenuTool
    extend Langchain::ToolDefinition

    Name = "cookie_menu"
    DESCRIPTION = "Access the Cozy Cookies menu, pricing, and current stock status."

    define_function :check_cookie_price, description: "Get the current price and availability for a specific cookie flavor." do
      property :flavor,
               type: "string",
               description: "The flavor slug (e.g., peanut_butter, biscoff, chocolate_chips, double_chocolate)",
               required: true
    end

    define_function :list_flavors, description: "List all available cookie flavors."
    

    def check_cookie_price(flavor:)
      normalized_slug = flavor.to_s.strip.downcase
      product = Product.find_by(slug: normalized_slug)

      if product
        {
          flavor: product.name,
          price: "#{product.price} LE",
          status: product.status # Returns "in_stock" or "out_of_stock" from ActiveRecord enum
        }.to_json
      else
        { error: "Flavor '#{flavor}' was not found on our menu." }.to_json
      end
    rescue StandardError => e
      Rails.logger.error("[CookieMenuTool] DB Error while looking up '#{flavor}': #{e.message}")
      { error: "Temporarily unable to query product inventory." }.to_json
    end

    def list_flavors
      flavors = Product.in_stock.pluck(:name)
      
      if flavors.any?
        { available_flavors: flavors }.to_json
      else
        { message: "We are currently sold out of all flavors." }.to_json
      end
    rescue StandardError => e
      # Isolation: Log DB errors locally without crashing the agent loop
      Rails.logger.error("[CookieMenuTool] DB Error while listing flavors: #{e.message}")
      { error: "Temporarily unable to fetch the menu." }.to_json
    end
  end

end