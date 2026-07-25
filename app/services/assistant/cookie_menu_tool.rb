module Assistant
    class CookieMenuTool
        extend Langchain::ToolDefinition

        Name = "cookie_menu"
        DESCRIPTION = "Access the Cozy Cookies menu and pricing."
        
        define_function :check_cookie_price, description: "Get the current price for a specific cookie flavor." do
            property :flavor, type: "string", description: "e.g., peanut_butter, chocolate, biscoff", required: true
        end

        def check_cookie_price(flavor:)
            # Your exact business logic, but safely isolated in its own method
            case flavor
            when "peanut_butter"
                { price: "160 LE", status: "in_stock" }.to_json
            when "biscoff"
                { price: "180 LE", status: "in_stock" }.to_json
            when "chocolate_chips"
                { price: "100 LE", status: "out_of_stock" }.to_json
            else
                { error: "Flavor not found in our menu." }.to_json
            end
        end
    end
end