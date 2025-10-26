class ApiEndpoints {
  static const baseUrl = "http://localhost:7001"; // node_gateway
  static const ragUrl = "http://localhost:8000"; // RAG microservice

  // Auth
  static const signup = "$baseUrl/signup";
  static const login = "$baseUrl/login";

  // Chat
  static const chat = "$ragUrl/callLLM/";
}
