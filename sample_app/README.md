# Sample App

### To start

1. Copy `env.sample` to `.env`.
2. Update `.env` with the appropriate values.
3. Start the app:

    ```bash
    bundle exec ruby app.rb
    ```

4. Visit: <http://localhost:4567> to verify that its started properly.

### Testing with a real FormSG Webhook with the sample app locally 

1. Install and configure [Ngrok](https://ngrok.com) 
2. Start an Ngrok session:

   ```bash
   ngrok http 4567
   ```

3. Note the `https` endpoint.
4. Update the "Webhook Endpoint URL" in your FormSG settings.
5. Try to submit a new form (ensure your form is active).
6. You should see the results in the sample app's terminal.
