NoiosoAI 🌌
This App Is a port of the android version made by my friend and It Allows You To Connect To Your Ollama Server By Using The Local IP (example. 10.1.1.1) (This Is An Beta There Are Still Some Issues)

✨ Features
NoiosoAI is a modern, privacy-focused iOS chat application designed to connect to your local Ollama server. It features a beautiful "green type of color" UI and a premium dark mode aesthetic.

Requires:
A PC With (Windows, Linux, MacOS)
8GB of RAM
At least 20-30GB of Storage
A CPU with 4 or 2 Threads (may use GPU even for faster speed)
Ollama
🚀 Getting Started
Pull a Model: I recommend using llama3.2:1b. Run: ollama pull llama3.2:1b
Start Server: Run OLLAMA_HOST=0.0.0.0 ollama serve
Connect: On your phone, put the local IP of your PC with :11434 at the end and select the model name.
Tip

Remote Access: If you want to use NoiosoAI from cellular data or outside your home, use Tailscale instead of port-forwarding. It's much more secure and provides a static IP for your PC.

Now you're ready to start chatting with your LLM locally!

🛠 Tech Stack
UI: Jetpack Compose
Network: Retrofit + OkHttp
JSON: Moshi
Async: Kotlin Coroutines & Flow
Data: Jetpack DataStore
📸 Screenshots
Screenshot_1 Screenshot_2

📄 License
Distributed under the MIT License. See LICENSE for more information.


Here is the original Project. Shoutout to my friend GaM1ngN0tDev
https://github.com/GaM1ngN0tDev/NoiosoAI
