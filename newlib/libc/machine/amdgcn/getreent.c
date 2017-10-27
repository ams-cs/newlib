/* get thread-specific reentrant pointer */

#include <reent.h>
#include <stdint.h>

/* Copied from the HSA documentation.  */
typedef struct hsa_signal_s {
  uint64_t handle;
} hsa_signal_t;
typedef struct hsa_kernel_dispatch_packet_s {
  uint16_t header ;
  uint16_t setup;
  uint16_t workgroup_size_x ;
  uint16_t workgroup_size_y ;
  uint16_t workgroup_size_z;
  uint16_t reserved0;
  uint32_t grid_size_x ;
  uint32_t grid_size_y ;
  uint32_t grid_size_z;
  uint32_t private_segment_size;
  uint32_t group_segment_size;
  uint64_t kernel_object;
  uint64_t reserved2;
  hsa_signal_t completion_signal;
} hsa_kernel_dispatch_packet_t;

struct _reent *
__getreent (void)
{
  /* Place the reent data at the top of the stack allocation.
     s[0:1] contains a 48-bit private segment base address.
     s11 contains the offset to the base of the stack.
     s[4:5] contains the dispatch pointer.  */
  long private_segment;
  int stack_offset;
  hsa_kernel_dispatch_packet_t *dispatch_ptr;

  asm("s_mov_b32 %L0, s0\n\t"
      "s_and_b32 %H0, s1, 0xffff"
      : "=Sg"(private_segment));
  asm("s_mov_b32 %0, s11"
      : "=Sg"(stack_offset));
  asm("s_mov_b64 %0, s[4:5]"
      : "=Sg"(dispatch_ptr));

  struct data {
    int marker;
    struct _reent reent;
  } *data;

  long stack_base = private_segment + stack_offset;
  long stack_end = stack_base + dispatch_ptr->private_segment_size * 64;
  long addr = (stack_end - sizeof(struct data)) & ~7;
  data = (struct data *)addr;

  if (data->marker != (int)(long)dispatch_ptr)
    {
      data->marker = (int)(long)dispatch_ptr;
      __builtin_memset (&data->reent, 0, sizeof(struct _reent));
      _REENT_INIT_PTR_ZEROED (&data->reent);
    }

  return &data->reent;
}

