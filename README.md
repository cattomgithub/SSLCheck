# SSL Check
![](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

一个检查 SSL 证书健康状况的 shell 脚本。

## 使用
本脚本有 `HTML` 输出和 `JSON` 输出两种模式。

`ssl_check_list` 文件存储需要检查的域名列表。

请将需要检查的域名按 `domain[:port]` 的格式输入至`ssl_check_list` 文件中。

```sh
git clone https://github.com/cattomgithub/SSLCheck.git

cd SSLCheck && sudo chmod +x ssl_check.sh

nano ssl_check_list

./ssl_check [HTML/JSON]
```

## 可供修改的变量
|    变量     |        默认值         |                    含义                    |
| :---------: | :-------------------: | :----------------------------------------: |
| `WORK_PATH` | `/root/logs/SSLCheck` | 脚本工作目录(存储脚本运行过程中的中间产物) |
| `LIST_FILE` | `$PWD/ssl_check_list` |           域名列表文件的存储位置           |
| `JSON_FILE` |  `$PWD/result.json`   |        `JSON` 模式输出文件存储位置         |
| `HTML_FILE` |   `$PWD/index.html`   |        `HTML` 模式输出文件存储位置         |

## 目前已经发现的问题
- `ssl_check_list` 文件最后需留空行，否则可能出现不可预知的错误...
