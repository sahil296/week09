# Traffic Generator Script for Product and Order Services
# This script generates continuous traffic to see real-time metrics in Prometheus and Grafana

Write-Host "Starting continuous traffic generation..." -ForegroundColor Green
Write-Host "Product Service: http://4.195.97.71:8000" -ForegroundColor Yellow
Write-Host "Order Service: http://4.200.79.151:8001" -ForegroundColor Yellow
Write-Host "Prometheus: http://4.254.85.157" -ForegroundColor Cyan
Write-Host "Grafana: http://4.200.99.154 (admin/admin)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop traffic generation" -ForegroundColor Red
Write-Host ""

$productId = 4
$userId = 4

while ($true) {
    try {
        # Create a new product every 10 iterations
        if ($productId % 10 -eq 0) {
            $productNames = @("Gaming Monitor", "USB Cable", "Phone Charger", "Laptop Stand", "Webcam", "Headphones", "Mouse Pad", "External HDD")
            $randomName = $productNames | Get-Random
            $randomPrice = [math]::Round((Get-Random -Minimum 20 -Maximum 500) + (Get-Random) * 0.99, 2)
            $randomStock = Get-Random -Minimum 5 -Maximum 100
            
            $body = @{
                name = "$randomName $productId"
                description = "Auto-generated product for metrics testing"
                price = $randomPrice
                stock_quantity = $randomStock
            } | ConvertTo-Json
            
            Invoke-RestMethod -Uri "http://4.195.97.71:8000/products" -Method POST -Body $body -ContentType "application/json" | Out-Null
            Write-Host "Created product: $randomName $productId" -ForegroundColor Green
        }
        
        # Create an order
        $orderBody = @{
            user_id = $userId
            shipping_address = "Auto-generated address $userId"
            status = "pending"
            items = @(
                @{
                    product_id = Get-Random -Minimum 1 -Maximum ([math]::Max(2, $productId))
                    quantity = Get-Random -Minimum 1 -Maximum 3
                    price_at_purchase = [math]::Round((Get-Random -Minimum 20 -Maximum 500) + (Get-Random) * 0.99, 2)
                }
            )
        } | ConvertTo-Json -Depth 3
        
        Invoke-RestMethod -Uri "http://4.200.79.151:8001/orders" -Method POST -Body $orderBody -ContentType "application/json" | Out-Null
        Write-Host "Created order for user $userId" -ForegroundColor Blue
        
        # Make several GET requests
        Invoke-RestMethod -Uri "http://4.195.97.71:8000/products" -Method GET | Out-Null
        Invoke-RestMethod -Uri "http://4.200.79.151:8001/orders" -Method GET | Out-Null
        Invoke-RestMethod -Uri "http://4.195.97.71:8000/health" -Method GET | Out-Null
        Invoke-RestMethod -Uri "http://4.200.79.151:8001/health" -Method GET | Out-Null
        
        # Get individual product/order by ID
        $randomProductId = Get-Random -Minimum 1 -Maximum ([math]::Max(2, $productId))
        Invoke-RestMethod -Uri "http://4.195.97.71:8000/products/$randomProductId" -Method GET -ErrorAction SilentlyContinue | Out-Null
        
        Write-Host "Generated traffic batch - Product ID: $productId, User ID: $userId" -ForegroundColor Gray
        
        $productId++
        $userId++
        
        Start-Sleep -Seconds 3
    }
    catch {
        Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
}