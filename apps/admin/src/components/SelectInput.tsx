import type { SelectHTMLAttributes } from "react";

export default function SelectInput({
  className = "",
  children,
  ...props
}: SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <div className={`select-wrap ${className}`.trim()}>
      <select className="select-input" {...props}>
        {children}
      </select>
    </div>
  );
}
