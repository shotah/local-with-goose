# Goose Extensions and Custom MCP Packages

This document explains how Goose works as an agent framework and how to extend it with custom tools through MCP (Model Control Protocol) packages.

## What is Goose?

Goose is a Rust-based agent framework that runs locally on your machine. It's designed to work with local LLMs through the Ollama provider, enabling natural language interaction with your local development environment while maintaining complete offline operation.

Key features:
- Fully offline operation
- Rust-based agent loop for memory efficiency
- Support for custom tools and extensions
- Integration with Ollama for local LLM serving
- MCP (Model Control Protocol) compatibility

## How Goose Works

Goose operates by:
1. Connecting to a local LLM through the Ollama provider
2. Receiving natural language instructions from users
3. Interpreting these instructions as actions to take on the local system
4. Leveraging available tools (through MCP protocol) to perform specific tasks
5. Executing actions and returning results

## Adding Custom MCP Packages

Goose supports extension through MCP (Model Control Protocol) packages, which allow you to add custom capabilities to the agent.

### Prerequisites for Adding Custom Tools

To create and integrate custom MCP packages:
1. Understand how MCP interfaces work
2. Ensure your system has the appropriate development tools
3. Familiarize yourself with the JSON-RPC protocol used by MCP

### Steps to Add Custom Tools

1. **Create a new MCP tool**:
   - Implement your tool using the MCP protocol specification
   - Define the tool's interface and capabilities
   - Package it with proper metadata

2. **Install and Register the Tool**:
   - Place your tool in a location where Goose can access it
   - Update configuration to include the new tool in the agent's capabilities

3. **Test Integration**:
   - Start a Goose session with `make session`
   - Ask Goose to use your new tool to verify integration

### Example Tool Structure

A basic MCP package typically includes:
```json
{
  "name": "tool-name",
  "version": "1.0.0",
  "description": "Description of your tool's functionality",
  "capabilities": {
    "tools": [
      {
        "name": "my-custom-tool",
        "description": "What this tool does",
        "input_schema": {
          "type": "object",
          "properties": {
            "parameter1": {"type": "string"}
          }
        }
      }
    ]
  }
}
```

## Extending the Local Coder Environment

Beyond custom tools, you can extend the local coding environment in several ways:

### 1. Custom Makefile Targets
You can add your own targets to the makefile for specific workflows:
```makefile
# Example of a custom target for code analysis
analyze-code:
	# Your command here
```

### 2. Model Selection
Extend the model selection capabilities by adding more models to the README and updating the makefile to support additional tags.

### 3. Environment Configuration
Customize environment variables or add new pre-flight checks for different workflows.

## Best Practices

1. **Security**: Always review custom tools before adding them to ensure they don't create security vulnerabilities
2. **Performance**: Be mindful of how many tools you load, as they can affect performance
3. **Documentation**: Document all your custom additions clearly
4. **Testing**: Test new tools in isolated environments before integrating them into regular workflows

## Further Resources

- [Goose GitHub Repository](https://github.com/aaif-goose/goose)
- [MCP Protocol Specification](https://github.com/ModelClientProtocol/spec)
- [Ollama Documentation](https://ollama.com/docs)
- [Goose CLI Installation Guide](https://goose-docs.ai/docs/getting-started/installation)
- [Built-in Platform Extensions](https://goose-docs.ai/docs/getting-started/using-extensions#built-in-platform-extensions)

## Troubleshooting

If you encounter issues with custom packages:
1. Check if the tool is properly installed and accessible
2. Verify JSON schema compliance
3. Ensure proper permissions for the tool binary or script
4. Review logs from both Goose and Ollama for error messages

## Built-in Platform Extensions

Goose comes with several built-in platform extensions that provide core functionality:

- **File System Operations**: Read, write, and manipulate files in your local environment
- **Shell Command Execution**: Run arbitrary shell commands securely
- **Code Analysis Tools**: Built-in support for common code analysis tools
- **Development Environment Integration**: Seamless integration with development workflows
- **Model Interaction**: Direct interaction with Ollama models for code generation and editing

## Enabling Web Search and Advanced Capabilities

Goose can be extended to include web search capabilities and other advanced features through:

### 1. Web Search Integration

To enable web search functionality, you can:
- Install a web search MCP package that integrates with search APIs
- Configure the tool to use services like DuckDuckGo, Tavily, or other search providers
- Add appropriate API keys to your environment variables (if required by specific services)

### 2. Custom MCP Packages

You can create or install custom MCP packages to extend Goose's capabilities:
- **API Integration Tools**: Connect to external APIs for data retrieval
- **Database Access**: Tools for working with local or remote databases
- **Cloud Services**: Integration with cloud platforms (AWS, GCP, Azure)
- **Specialized Code Analysis**: Advanced linting, testing, or security scanning tools

### 3. Extension Management

Goose supports:
- **Installing new extensions** via package managers or direct installation
- **Configuring extension settings** through environment variables
- **Managing tool availability** and permissions for different capabilities
- **Updating existing extensions** to newer versions

### 4. Environment Configuration

To enable additional features:
1. Set up proper environment variables in your `.env` file or shell configuration
2. Install required dependencies for the tools you want to use
3. Configure access tokens or API keys if needed by external services
4. Ensure network connectivity is properly configured for web-based operations

### 5. Example: Adding a Web Search Tool

To add web search capabilities, you might need to:
- Create or find an MCP-compatible web search tool
- Add the tool to your Goose configuration
- Configure appropriate rate limits and usage parameters
- Test that it works correctly within the local environment

## Advanced Usage Patterns

Once extended with additional capabilities, Goose can:
- Perform research using web search
- Automatically fetch relevant documentation
- Integrate with CI/CD pipelines
- Connect to external databases for data analysis
- Access cloud services programmatically
- Execute complex multi-step workflows across different platforms

## Security Considerations

When enabling additional capabilities:
- Review all tools and their permissions
- Understand what data flows through each tool
- Apply appropriate rate limiting to API calls
- Ensure proper authentication for external services
- Monitor usage and costs for paid services