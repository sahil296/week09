# Heavy Traffic Generator Script
# Generates ~400 requests to each service for comprehensive metrics

Write-Host "🚀 Starting heavy traffic generation..." -ForegroundColor Green
Write-Host "Target: ~400 requests per service" -ForegroundColor Yellow
Write-Host "Product Service: http://4.195.97.71:8000" -ForegroundColor Cyan
Write-Host "Order Service: http://4.200.79.151:8001" -ForegroundColor Cyan
Write-Host ""

$totalBatches = 50
$requestsPerBatch = 8  # This will give us ~400 total requests
$productCounter = 4
$userCounter = 4
$orderCounter = 4

Write-Host "⏳ Generating $($totalBatches * $requestsPerBatch) requests per service..." -ForegroundColor White

for ($batch = 1; $batch -le $totalBatches; $batch++) {
    
    # Create a product every 5 batches
    if ($batch % 5 -eq 0) {
        try {
            $productNames = @("Gaming Monitor", "USB Cable", "Phone Charger", "Laptop Stand", "Webcam", "Headphones", "Mouse Pad", "External SSD", "Bluetooth Speaker", "Wireless Keyboard")
            $randomName = $productNames | Get-Random
            $randomPrice = [math]::Round((Get-Random -Minimum 25 -Maximum 899) + (Get-Random) * 0.99, 2)
            $randomStock = Get-Random -Minimum 10 -Maximum 150
            
            $body = @{
                name = "$randomName Pro $productCounter"
                description = "Premium $randomName for professional use"
                price = $randomPrice
                stock_quantity = $randomStock
            } | ConvertTo-Json
            
            Invoke-RestMethod -Uri "http://4.195.97.71:8000/products" -Method POST -Body $body -ContentType "application/json" -ErrorAction SilentlyContinue | Out-Null
            $productCounter++
        }
        catch {
            # Continue on error
        }
    }
    
    # Create an order every 3 batches
    if ($batch % 3 -eq 0) {
        try {
            $orderBody = @{
                user_id = $userCounter
                shipping_address = "Test Address $userCounter, Suite $batch"
                status = "pending"
                items = @(
                    @{
                        product_id = Get-Random -Minimum 1 -Maximum ([math]::Max(2, $productCounter))
                        quantity = Get-Random -Minimum 1 -Maximum 4
                        price_at_purchase = [math]::Round((Get-Random -Minimum 15 -Maximum 799) + (Get-Random) * 0.99, 2)
                    }
                )
            } | ConvertTo-Json -Depth 3
            
            Invoke-RestMethod -Uri "http://4.200.79.151:8001/orders" -Method POST -Body $orderBody -ContentType "application/json" -ErrorAction SilentlyContinue | Out-Null
            $userCounter++
            $orderCounter++
        }
        catch {
            # Continue on error
        }
    }
    
    # Generate 8 requests per batch (mix of different endpoints)
    for ($i = 1; $i -le $requestsPerBatch; $i++) {
        try {
            # Product service requests
            switch ($i) {
                1 { Invoke-RestMethod -Uri "http://4.195.97.71:8000/products" -Method GET -ErrorAction SilentlyContinue | Out-Null }
                2 { Invoke-RestMethod -Uri "http://4.195.97.71:8000/health" -Method GET -ErrorAction SilentlyContinue | Out-Null }
                3 { 
                    $randomProductId = Get-Random -Minimum 1 -Maximum ([math]::Max(2, $productCounter))
                    Invoke-RestMethod -Uri "http://4.195.97.71:8000/products/$randomProductId" -Method GET -ErrorAction SilentlyContinue | Out-Null 
                }
                4 { Invoke-RestMethod -Uri "http://4.195.97.71:8000/" -Method GET -ErrorAction SilentlyContinue | Out-Null }
                5 { Invoke-RestMethod -Uri "http://4.200.79.151:8001/orders" -Method GET -ErrorAction SilentlyContinue | Out-Null }
                6 { Invoke-RestMethod -Uri "http://4.200.79.151:8001/health" -Method GET -ErrorAction SilentlyContinue | Out-Null }
                7 { 
                    $randomOrderId = Get-Random -Minimum 1 -Maximum ([math]::Max(2, $orderCounter))
                    Invoke-RestMethod -Uri "http://4.200.79.151:8001/orders/$randomOrderId" -Method GET -ErrorAction SilentlyContinue | Out-Null 
                }
                8 { Invoke-RestMethod -Uri "http://4.200.79.151:8001/" -Method GET -ErrorAction SilentlyContinue | Out-Null }
            }
        }
        catch {
            # Continue on error
        }
    }
    
    # Progress indicator
    if ($batch % 5 -eq 0) {
        $completed = [math]::Round(($batch / $totalBatches) * 100, 1)
        Write-Host "📊 Progress: $completed% ($batch/$totalBatches batches) - Products: $productCounter, Orders: $orderCounter" -ForegroundColor Yellow
    }
    
    # Small delay to avoid overwhelming the services
    Start-Sleep -Milliseconds 100
}

Write-Host ""
Write-Host "✅ Traffic generation complete!" -ForegroundColor Green
Write-Host "📈 Generated approximately $($totalBatches * $requestsPerBatch) requests per service" -ForegroundColor Green
Write-Host "🆕 Created $($productCounter - 4) new products" -ForegroundColor Green  
Write-Host "📦 Created $($orderCounter - 4) new orders" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Check your metrics now in:" -ForegroundColor Cyan
Write-Host "   • Prometheus: http://4.254.85.157" -ForegroundColor White
Write-Host "   • Grafana: http://4.200.99.154" -ForegroundColor White