# Satoshi Twins API

<div align="center">
  <img  src="https://github.com/user-attachments/assets/6d383814-3c4c-4d33-9738-7798defd4f81" alt="logo" width="200"  height="auto" />
  <img  src="https://github.com/user-attachments/assets/6d383814-3c4c-4d33-9738-7798defd4f81" alt="logo" width="200"  height="auto" />
  <br/>

<h3><b>Satoshi Twins API</b></h3>
</div>

# 📗 Table of Contents

- [📖 About the Project](#about-project)
    - [🛠 Built With](#built-with)
    - [Tech Stack](#tech-stack)
    - [Key Features](#key-features)
- [🧑🏻‍💻 Live Demo](#live-demo)
- [🧑🏻‍💻 Data Base Schema](#dbschema)
- [💻 Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Clone](#prerequisites)
    - [Install](#install)
    - [Run tests](#run-tests)
- [👥 Authors](#authors)
- [🔭 Future Features](#future-features)
- [🤝 Contributing](#contributing)
- [⭐️ Show your support](#support)
- [📝 License](#license)

# 📖 Satoshi Twins API Project <a name="about-project"></a>

> Satoshi Twins Project is an API designed to handle cryptocurrency conversions seamlessly. It provides real-time exchange rates and ensures accurate calculations for financial applications.

## 🛠 Built With <a name="built-with"></a>

- Ruby Mine IDE
- Ruby 3.3.1
- Github

### Tech Stack <a name="tech-stack"></a>

<details>
  <summary>Backend</summary>
  <ul>
    <li><a href="https://en.wikipedia.org/wiki/HTML">Ruby on Rails 8.0.2</a></li>
    
  </ul>
</details>

<!-- Features -->

#### Key Features <a name="key-features"></a>

 <ul>
  <li>Handle authentication via JWT using devise and devise_token_auth </li>
  <li>Cors Policy</li>
  <li>Welcome on Board service to initialize "initial wallets"</li>
  <li>Overwrite Devise Token Auth gem controllers to use the service in the same flow</li>
  <li>CryptoPriceTracker Service to handle crypto prices conversions</li>
  <li>CoingeckoService to integrate to Coingecko.com</li>
  <li>International Currency Format in all responses</li>
  <li>ExchangeService to handle wallet exchanges</li>
  <li>Automatic calculation of amount to receive</li>
  <li>Docker compose file ready to build</li>
  <li>Rspec tests for all use cases</li>
 </ul>
<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🧑🏻‍💻 Live Demo <a name="live-demo"></a>

[https://satoshitwins-production.up.railway.app/](https://satoshitwins-production.up.railway.app/)

## 🧑🏻‍💻 Data Base Schema <a name="dbschema"></a>

![image](https://github.com/user-attachments/assets/d80aa766-abf2-44a2-a572-0eeca0d6606a)


## 💻 Getting Started <a name="getting-started"></a>

To get a local copy, follow these steps.

### Prerequisites

In order to run this project you need: Docker installed in your system

### Clone

Clone this repository to your desired folder:

```sh
  git clone git@github.com:chelobotix/satoshi_twins.git
```

### Install

Install this project with:

```sh
  docker compose build
  docker compose up -d
  docker compose exec app bundle exec rails db:migrate
  docker compose exec app bundle exec rails db:seed
```

### Run tests

To run RSPEC tests, run the following command:

```sh
  rspec --exclude-pattern "spec/requests/**/*_spec.rb"
```

### Use App

Crate a new user in:

```sh
  POST: /auth
  {
    "email": "usertest1@gmail.com",
    "password": "111111",
    "password_confirmation": "111111"
  }
```

Login in:

```sh
  POST: /auth/sign_in
  {
    "email": "usertest1@gmail.com",
    "password": "111111"
  }
```
Copy the token generated in the response headers:
![Pasted Graphic 1](https://github.com/user-attachments/assets/0f815d00-1527-424d-b485-3ad6781baa0c)

Use it in your requests headers:
![Pasted Graphic 2](https://github.com/user-attachments/assets/b84d502d-2e79-40a0-ab73-ad827490a910)



Visit the endpoint:
[https://satoshitwins-production.up.railway.app/api-docs/index.html](https://satoshitwins-production.up.railway.app/api-docs/index.html)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- AUTHORS -->

## 👥 Author <a name="authors"></a>

👤 **Author1**

: Marcelo Alarcon

Bolivia 💓

- GitHub: [@Marcelo Alarcon](https://github.com/chelobotix)
- Twitter: [@Marcelo Alarcon](https://twitter.com/marcealarconb)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🔭 Future Features <a name="future-features"></a>

<ul>
  <li>Add Custom Wallet Creation</li>
  <li>Add More Currencies</li>
</ul>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🤝 Contributing <a name="contributing"></a>

Contributions, issues, and feature requests are welcome!
Feel free to check the [issues page](https://github.com/chelobotix/Retro-Watchers-Capstone/issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## ⭐️ Show your support <a name="support"></a>

If you like this project please let me know


<p align="right">(<a href="#readme-top">back to top</a>)</p>


## 📝 License <a name="license"></a>

This project is MIT licensed.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
