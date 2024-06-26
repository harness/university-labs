import http from 'k6/http';
import { sleep } from 'k6';
import { check, group, fail } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 3 },
    { duration: '1m30s', target: 9 },
    { duration: '20s', target: 0 },
  ],
};

function randomString(length, charset = '') {
  if (!charset) charset = 'abcdefghijklmnopqrstuvwxyz';
  let res = '';
  while (length--) res += charset[(Math.random() * charset.length) | 0];
  return res;
}

function randomPhone(length, charset = '') {
  if (!charset) charset = '0123456789';
  let res = '';
  while (length--) res += charset[(Math.random() * charset.length) | 0];
  return res;
}

const NAME = `${randomString(10)}`; 
const EMAIL = `${NAME}@example.com`;
const PHONE = `${randomPhone(10)}`; 

const BASE_URL = 'http://localhost:8080';

export default function () {

  let URL = `${BASE_URL}/api/v1`;


  group('01. Create a new record', () => {
      const payload = {
          "name": NAME,
          "email": EMAIL,
          "phone": PHONE,
      };

      const res = http.post(`${URL}/create`, JSON.stringify(payload), {
        headers: { 'Content-Type': 'application/json' },
      });

      if (check(res, { 'Account created successfully': (r) => r.status === 200 })) {
          console.log(`Successfully created a new record ${res.status} ${res.body}`);
      } else {
          console.log(`Unable to create a new record ${res.status} ${res.body}`);
          return;
      }
  });

  group('02. Fetch one records', () => {
      const res = http.get(`${URL}/fetch?email=${EMAIL}`);
      check(res, { 'retrieved status': (r) => r.status === 200 });
      check(res.json(), { 'retrieved record': (r) => r.length > 0 });
  });

  group('03. Update the record', () => {

      const payload = {
          name: NAME,
          email: EMAIL,
          phone: '1234567890',
      };
      const res = http.put(`${URL}/update`, JSON.stringify(payload),{
        headers: { 'Content-Type': 'application/json' },
      });
      const isSuccessfulUpdate = check(res, {
          'Update worked': () => res.status === 200,
      });

      if (!isSuccessfulUpdate) {
          console.log(`Unable to update the record ${res.status} ${res.body}`);
          return;
      }
  });

  group('04. Delete the record', () => {
      const delRes = http.del(`${URL}/delete?email=${EMAIL}`);

      const isSuccessfulDelete = check(delRes, {
          'Record was deleted correctly': () => delRes.status === 200,
      });

      if (!isSuccessfulDelete) {
          console.log(`Record was not deleted properly`);
          return;
      }
  });

};