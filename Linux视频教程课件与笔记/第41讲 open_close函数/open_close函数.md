## open_close函数

### OPEN函数

头文件：

```
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
```

函数原型：

- 当文件存在时

  ```
  int open(const char* pathname,int flags)
  ```

- 当文件不存在时

  ```
  int open (const char* pathname,int flags,int perms)
  ```

返回值

成功：文件描述符

失败：-1

### CLOSE函数

头文件：

```
#include <unistd.h>
```

函数原型：

```
int close(int fd)
```

返回值：

成功：0

失败：-1



