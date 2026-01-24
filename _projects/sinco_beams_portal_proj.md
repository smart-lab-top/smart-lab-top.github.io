---
layout: page
title: "Sinco Beams Profiler Portal"
description: "Advanced web portal for Sinco Beams acoustic profiling and data analysis"
img: assets/img/cincobeams.png
importance: 1
category: work
---

## Sinco Beams Profiler Portal

An advanced web portal for Sinco Beams acoustic profiling, real-time data visualization, and marine ecosystem analysis.

### Key Features

- **Acoustic Profiling**: Advanced beamforming and acoustic profiling capabilities
- **Real-time Data Processing**: Live processing of underwater acoustic signals
- **3D Visualization**: Interactive 3D visualization of acoustic data and beam patterns
- **Environmental Monitoring**: Continuous monitoring of underwater acoustic environments
- **Data Export**: Export processed data for further analysis

### Technology Stack

- **Frontend**: Modern web interface with 3D rendering capabilities
- **Backend**: High-performance acoustic signal processing
- **Database**: Specialized storage for acoustic time-series data
- **Processing**: Advanced algorithms for beamforming and profiling

### Research Applications

This portal supports research in:
- Underwater acoustic beamforming
- Marine acoustic profiling
- Fisheries acoustic surveys
- Oceanographic data collection
- Environmental acoustics monitoring

### Technical Specifications

- **Beam Types**: Support for multiple beam configurations
- **Frequency Range**: Broadband acoustic processing capabilities
- **Real-time Processing**: Live data streaming and analysis
- **Data Formats**: Multiple export formats for research data

### Future Developments

Planned enhancements include:
- Advanced beam steering algorithms
- Machine learning integration for pattern recognition
- Extended frequency range capabilities
- Multi-platform data integration

---

## Access the Portal

<div id="access-section">
  <p>This portal requires authentication for access. Please enter the password to continue:</p>

  <div class="password-form" style="max-width: 400px; margin: 20px auto;">
    <div class="input-group mb-3">
      <input type="password" class="form-control" id="portal-password" placeholder="Enter password" aria-label="Password">
      <div class="input-group-append">
        <button class="btn btn-primary" type="button" onclick="verifyPassword('smartlab2024', 'http://47.93.91.76:8000/')">
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
    verifyPassword('smartlab2024', 'http://47.93.91.76:8000/');
  }
});
</script>

---

*For technical support or feature requests, please contact the SMART Lab development team.*