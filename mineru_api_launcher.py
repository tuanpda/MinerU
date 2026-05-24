"""Start mineru-api with MKLDNN disabled (avoids 'could not create a primitive' on some VPS CPUs)."""
import torch

torch.backends.mkldnn.enabled = False

from mineru.cli.fast_api import main

if __name__ == "__main__":
    main()
