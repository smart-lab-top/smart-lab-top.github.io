---
layout: page
title: "Ecoacoustic Buoy Portal"
description: "Real-time monitoring and data visualization platform for ecoacoustic buoys"
img: assets/img/ecobuoy.png
importance: 2
category: work
---

## Ecoacoustic Buoy Portal

An advanced web portal for real-time monitoring and analysis of ecoacoustic buoy data.

### Key Features

- **Real-time Data Streaming**: Live acoustic data from deployed buoys
- **Environmental Monitoring**: Continuous tracking of underwater noise levels
- **Species Detection**: Automated identification of marine mammal vocalizations
- **Data Visualization**: Interactive charts and spectrograms
- **Alert System**: Automated notifications for significant acoustic events

### Technology Stack

- **Frontend**: Responsive web interface with real-time updates
- **Backend**: High-performance data processing and analysis
- **Database**: Time-series database for acoustic data storage
- **Machine Learning**: AI-powered species classification and anomaly detection

### Research Applications

This portal supports:
- Long-term environmental impact assessments
- Marine protected area monitoring
- Fisheries acoustic surveys
- Climate change impact studies on marine ecosystems

### Deployment Status

- **Active Buoys**: Multiple buoys deployed in key marine locations
- **Data Collection**: 24/7 continuous monitoring
- **Data Retention**: Historical data archive for trend analysis
- **API Access**: Programmatic access for research applications

### Future Enhancements

Planned improvements include:
- Mobile app companion
- Advanced AI analytics
- Integration with satellite data
- Public data sharing portal

---

## Access the Portal

<div id="access-section">
  <p>This portal requires authentication for access. Please enter the password to continue:</p>

  <div class="password-form" style="max-width: 400px; margin: 20px auto;">
    <div class="input-group mb-3">
      <input type="password" class="form-control" id="portal-password" placeholder="Enter password" aria-label="Password">
      <div class="input-group-append">
        <button class="btn btn-primary" type="button" onclick="verifyPassword('smartlab2024', 'http://47.93.91.76:7001/')">
          <i class="fa-solid fa-lock-open"></i> Access Portal
        </button>
      </div>
    </div>
    <div id="password-error" class="text-danger" style="display: none;"></div>
  </div>
</div>

<script>
function verifyPassword(correctPassword, redirectUrl) {
  const password = document.getElementById('portal-password').value;
  const errorDiv = document.getElementById('password-error');

  if (password === correctPassword) {
    errorDiv.style.display = 'none';
    // Show success message and redirect
    const accessSection = document.getElementById('access-section');
    accessSection.innerHTML = `
      <div class="alert alert-success" role="alert">
        <i class="fa-solid fa-check-circle"></i> Password verified! Redirecting to portal...
      </div>
    `;
    setTimeout(() => {
      window.open(redirectUrl, '_blank');
    }, 1500);
  } else {
    errorDiv.style.display = 'block';
    errorDiv.textContent = 'Incorrect password. Please try again.';
    document.getElementById('portal-password').value = '';
    document.getElementById('portal-password').focus();
  }
}

// Allow Enter key to submit
document.getElementById('portal-password').addEventListener('keypress', function(event) {
  if (event.key === 'Enter') {
    verifyPassword('smartlab2024', 'http://47.93.91.76:7001/');
  }
});
</script>

---

*For technical support or data access requests, please contact the SMART Lab team.*