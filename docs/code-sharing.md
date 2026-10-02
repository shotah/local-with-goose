# Sharing Code with Goose

Unlike Cursor where you might use `Cmd+L` to share selected code, Goose works differently by providing context through file paths, specific code segments, or natural language descriptions.

## Methods for Sharing Code with Goose

### 1. **File Path References**
You can reference specific files directly:
```
"Please review the changes in my main.py file"
"Look at the function in utils/database.py"
"Examine the API endpoints in api/routes/users.py"
```

### 2. **Inline Code Sharing**
When you want to share specific code segments, you can:
- Reference specific lines: "In the authentication.py file, look at lines 15-25"
- Share exact code blocks when you're in a Goose session
- Use natural language to describe what you want changed/analyzed

### 3. **Workspace Navigation**
A Goose session starts in `GOOSE_WORKING_DIR` (saved by `make setup-shell`), so Goose has access to that project directory structure:
```
# You can ask questions like:
"Analyze how the database connection is established in my project"
"Show me all the models in this application"
"Find any unused imports in the controllers directory"
```

### 4. **Visual Code Reference**
If you want to reference specific lines or sections of code:
- You can tell Goose exactly which file and what part you're interested in
- Example: "In user_service.py, lines 100-120 are the authentication logic that needs review"
- Provide context for your request so Goose can accurately locate the relevant code

### 5. **Natural Language Prompts**
The most effective way is often:
```
"Explain how the login flow works in this repository"
"Show me how to implement a similar pattern to what's in auth.py"
"Refactor this function to make it more readable"
"This code looks inefficient - can you suggest improvements?"
```

## Practical Examples

### Example 1: Requesting Code Review
```
Can you review the authentication logic in my project? I'm particularly concerned about line 42-47 in auth.py where JWT tokens are handled.
```

### Example 2: Asking for a Specific Feature
```
I want to add user preferences functionality. Can you help implement a system similar to what's shown in user_profile.py but following the patterns from settings_service.py?
```

### Example 3: Explaining Code
```
What is happening in lines 15-30 of the database_connections.py file?
```

## Best Practices for Code Sharing

1. **Be Specific**: Reference exact files and line numbers when needed
2. **Context First**: Tell Goose what you're working on and what specific part to focus on
3. **Use Natural Language**: Describe what you want achieved, not how to achieve it
4. **Leverage Workspace Navigation**: Since Goose sees your entire workspace, it can navigate between files

## Working with Multiple Files

You can ask Goose to:
- Compare implementations across different files
- Analyze patterns and suggest improvements
- Explain relationships between code modules
- Help with refactoring that spans multiple files