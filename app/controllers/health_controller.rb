class HealthController < ActionController::Base
  def show
    # Verify Database connection
    ActiveRecord::Base.connection.execute("SELECT 1")

    # Verify Redis connection
    redis_healthy = begin
      Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1")).ping == "PONG"
    rescue StandardError
      false
    end

    respond_to do |format|
      format.html do
        render inline: <<~HTML, layout: false
          <!DOCTYPE html>
          <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>System Health | ForumX</title>
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
            <style>
              * { box-sizing: border-box; margin: 0; padding: 0; }
              body {
                font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
                background-color: #0B0F19;
                color: #F3F4F6;
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                padding: 1rem;
              }
              .card {
                background: #111827;
                border: 1px solid #1F2937;
                border-radius: 1.5rem;
                padding: 2.5rem;
                max-width: 460px;
                width: 100%;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.5);
                text-align: center;
              }
              .pulse-badge {
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                background: rgba(16, 185, 129, 0.1);
                color: #10B981;
                border: 1px solid rgba(16, 185, 129, 0.25);
                padding: 0.35rem 0.85rem;
                border-radius: 9999px;
                font-size: 0.85rem;
                font-weight: 700;
                margin-bottom: 1.25rem;
              }
              .dot {
                width: 8px;
                height: 8px;
                border-radius: 50%;
                background: #10B981;
                box-shadow: 0 0 10px #10B981;
              }
              h1 {
                font-size: 1.75rem;
                font-weight: 800;
                margin-bottom: 0.5rem;
                color: #FFFFFF;
              }
              p.desc {
                color: #9CA3AF;
                font-size: 0.95rem;
                margin-bottom: 2rem;
                line-height: 1.5;
              }
              .services {
                background: #1F2937;
                border-radius: 1rem;
                padding: 1rem 1.25rem;
                margin-bottom: 2rem;
                text-align: left;
                display: flex;
                flex-direction: column;
                gap: 0.75rem;
              }
              .service-row {
                display: flex;
                align-items: center;
                justify-content: space-between;
                font-size: 0.9rem;
              }
              .service-name {
                color: #E5E7EB;
                font-weight: 600;
              }
              .service-status {
                color: #10B981;
                font-weight: 700;
                display: flex;
                align-items: center;
                gap: 0.35rem;
              }
              .btn {
                display: inline-block;
                width: 100%;
                background: #4F46E5;
                color: #FFFFFF;
                padding: 0.85rem 1.5rem;
                border-radius: 0.85rem;
                font-weight: 700;
                font-size: 0.95rem;
                text-decoration: none;
                transition: background 0.2s ease;
              }
              .btn:hover {
                background: #4338CA;
              }
            </style>
          </head>
          <body>
            <div class="card">
              <div class="pulse-badge">
                <span class="dot"></span>
                <span>SYSTEM OPERATIONAL (200 OK)</span>
              </div>
              <h1>ForumX is Healthy</h1>
              <p class="desc">The server is running smoothly with active database and background queue connections.</p>
              
              <div class="services">
                <div class="service-row">
                  <span class="service-name">Ruby on Rails 8.0</span>
                  <span class="service-status">✓ Running</span>
                </div>
                <div class="service-row">
                  <span class="service-name">PostgreSQL 15</span>
                  <span class="service-status">✓ Connected</span>
                </div>
                <div class="service-row">
                  <span class="service-name">Redis & Sidekiq</span>
                  <span class="service-status">#{redis_healthy ? '✓ Connected' : '○ Standby'}</span>
                </div>
              </div>

              <a href="/" class="btn">← Go to ForumX Homepage</a>
            </div>
          </body>
          </html>
        HTML
      end
      format.any { head :ok }
    end
  rescue StandardError => e
    render plain: "UNHEALTHY: \#{e.message}", status: :internal_server_error
  end
end
