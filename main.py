import os
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate

load_dotenv()


llm = ChatOpenAI(
    model="nvidia/nemotron-nano-9b-v2:free",
    temperature=0.5,
    api_key=os.getenv("OPENROUTER_API_KEY"),
    max_tokens=50,
    max_retries=3,
    base_url="https://openrouter.ai/api/v1",
    streaming=True 
)

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are an AI assistant for Gautam Buddha University."),
    ("user", "{input}")
])

def call_llm_stream(input_string: str):
    chain = prompt | llm
    # chain.stream() gives chunks as they come
    for chunk in chain.stream({"input": input_string}):
        if chunk.content:   # sometimes chunks may be empty
            print(chunk.content, end="", flush=True)
    print()  # newline after streaming

if __name__ == "__main__":
    call_llm_stream("When will the semester exams be held?")
