import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Métricas customizadas
const errorRate = new Rate('errors');

// Configuração do teste
export const options = {
  stages: [
    { duration: '5m', target: 100 }, // Sobe para 1000 usuários em 5 minutos
    { duration: '5m', target: 100 }, // Mantém 1000 usuários por 5 minutos
  ],
  thresholds: {
    http_req_duration: ['p(95)<400'], // 95% das requisições devem ser < 5s
    http_req_duration: ['avg<200'],   // Tempo médio < 1s
    http_req_failed: ['rate<0.05'],    // Taxa de erro < 5%
  },
};

// Dados para os carros
const carNames = ['Gol', 'Uno', 'Civic', 'Corolla', 'Fusca', 'Palio', 'Fiesta', 'Ka', 'Onix', 'HB20', 'Sandero', 'Logan', 'Duster', 'Kicks', 'Compass'];
const manufacturers = ['Volkswagen', 'Fiat', 'Honda', 'Toyota', 'Ford', 'Chevrolet', 'Hyundai', 'Renault', 'Nissan', 'Jeep', 'Peugeot', 'Citroën', 'Kia', 'Mitsubishi', 'Mazda'];

function getRandomCar() {
  const name = carNames[Math.floor(Math.random() * carNames.length)];
  const manufacture = manufacturers[Math.floor(Math.random() * manufacturers.length)];
  const year = Math.floor(Math.random() * (2024 - 1990 + 1)) + 1990;
  
  return { name, manufacture, year };
}

export default function () {
  const car = getRandomCar();
  
  const payload = JSON.stringify(car);
  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  // Teste do serviço Coroutine (porta 8080)
  const coroutineResponse = http.post('http://host.docker.internal:8080/car', payload, params);
  
  check(coroutineResponse, {
    'Coroutine - Status is 200/201': (r) => r.status === 200 || r.status === 201,
    'Coroutine - Response time < 5000ms': (r) => r.timings.duration < 5000,
  }) || errorRate.add(1);

  // Teste do serviço Virtual Thread (porta 8081)
  const virtualThreadResponse = http.post('http://host.docker.internal:8081/car', payload, params);
  
  check(virtualThreadResponse, {
    'Virtual Thread - Status is 200/201': (r) => r.status === 200 || r.status === 201,
    'Virtual Thread - Response time < 5000ms': (r) => r.timings.duration < 5000,
  }) || errorRate.add(1);

  // Pequena pausa entre requisições
  sleep(Math.random() * 2);
}