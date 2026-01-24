---
layout: page
title: people
permalink: /people/
description: Meet the team behind SMART Lab.
nav: true
nav_order: 8
dropdown: true
children:
  - title: "Team Members"
    permalink: "/people/"
  - title: "Join Us"
    permalink: "/join/"
---

## Principal Investigator

<div class="row">
    <div class="col-sm-4 mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/prof_pic.jpg" class="img-fluid rounded z-depth-1" %}
    </div>
    <div class="col-sm-8 mt-3 mt-md-0">
        <h3>Jianfeng Tong (童剑锋), Ph.D.</h3>
        <p><strong>Associate Professor</strong><br>
        College of Marine Living Resource Sciences and Management<br>
        Shanghai Ocean University</p>
        
        <p>
            <a href="mailto:jftong@shou.edu.cn"><i class="fa-solid fa-envelope"></i> jftong@shou.edu.cn</a> | 
            <a href="{{ '/cv/' | relative_url }}"><i class="fa-solid fa-file-pdf"></i> CV</a>
        </p>

        <p>I received my Ph.D. in Applied Marine Environmental Studies (Engineering) from the Tokyo University of Marine Science and Technology, Japan, in 2015. I also hold an M.Sc. in Fisheries Resources and a B.Eng. in Marine Fisheries Science and Technology from Shanghai Ocean University.</p>
        
        <p>Currently, I am a Visiting Scholar at the University of Washington (2025.02 - Present). My research focuses on Fisheries Acoustics, Marine Bioacoustics, and Marine Living Resources Survey Techniques.</p>

        <h5>Professional Experience</h5>
        <ul>
            <li><strong>Visiting Scholar</strong>, University of Washington (2025.02 - Present)</li>
            <li><strong>Associate Professor</strong>, Shanghai Ocean University (2021.12 - Present)</li>
            <li><strong>Assistant Professor</strong>, Shanghai Ocean University (2017.06 - 2021.11)</li>
            <li><strong>Postdoctoral Researcher</strong>, Shanghai Ocean University (2015.05 - 2017.06)</li>
        </ul>
    </div>
</div>

---

## Current Lab Members

### Research Assistants
<div class="row row-cols-1 row-cols-md-3">
{% assign research_assistants = site.people | where: "category", "assistant" | sort: "importance" %}
{% for person in research_assistants %}
  {% include people.liquid %}
{% endfor %}
</div>

### PhD Students
<div class="row row-cols-1 row-cols-md-3">
{% assign phd_students = site.people | where: "category", "phd" | sort: "importance" %}
{% for person in phd_students %}
  {% include people.liquid %}
{% endfor %}
</div>

### Master Students
<div class="row row-cols-1 row-cols-md-3">
{% assign master_students = site.people | where: "category", "master" | sort: "importance" %}
{% for person in master_students %}
  {% include people.liquid %}
{% endfor %}
</div>

---

## Lab Alumni

<div class="row row-cols-1 row-cols-md-3">
{% assign alumni = site.people | where: "category", "alumni" | sort: "importance" %}
{% for person in alumni %}
  {% include people.liquid %}
{% endfor %}
</div>